module Final_A(input wire CLOCK_50, 
	input wire [3:0] KEY, 
	input wire [9:0] SW,
	output wire VGA_HS, // horizontal sync
	output wire VGA_VS, // vertical sync
	output wire [7:0] VGA_R,
	output wire [7:0] VGA_G,
	output wire [7:0] VGA_B,
	output wire VGA_BLANK_N, //blanking signal
	output wire VGA_SYNC_N, //sync signal
	output wire VGA_CLK,
	output wire [9:0] LEDR);
	
//internal signals
reg clk_25mhz;
wire rst;
wire video_on;
wire [9:0] pixel_x;
wire [9:0] pixel_y;
wire hsync;
wire vsync;

//game logic signals
wire [9:0] paddle_x;
wire [9:0] ball_x;
wire [9:0] ball_y;
wire [39:0] blocks;
wire game_over;
wire frame_tick;

//graphics signals
wire [7:0] vga_r;
wire [7:0] vga_g;
wire [7:0] vga_b;

wire [3:0] paddle_control;
reg [1:0] key_sync [2:0];
assign rst = ~KEY[0];
integer i;

always @(posedge clk_25mhz)
begin 
	for (i=0; i<3; i = i+1) begin
		key_sync[i] <= {key_sync[i][0], ~KEY[i+1]};
	end
end

//paddle control
assign paddle_control[0] = key_sync[0][1]; //starts paddle
assign paddle_control[1] = key_sync[2][1]; //moves paddle left
assign paddle_control[2] = key_sync[1][1]; //moves paddle right
assign paddle_control[3] = 1'b0;


always @(posedge CLOCK_50) begin
		clk_25mhz <= ~clk_25mhz;
end

//frame ticks
reg [19:0] frame_counter;
reg frame_tick_reg;

always @(posedge clk_25mhz) begin
	if(rst) begin
		frame_counter <= 1'b0;
		frame_tick_reg <= 1'b0;
	end
	else begin
		if(frame_counter == 20'd416666) begin
			frame_counter <= 20'b0;
			frame_tick_reg <= 1'b1;
		end
		else begin
			frame_counter <= frame_counter + 1'b1;
			frame_tick_reg <= 1'b0;
		end
	end
end

assign frame_tick = frame_tick_reg;

//VGA controller instantiation 
vga_controller vga_ctrl(clk_25mhz, rst, hsync, vsync, video_on, pixel_x, pixel_y);

//game logic instantiation
game_logic game(clk_25mhz, rst, frame_tick, paddle_control, paddle_x, ball_x, ball_y, blocks, game_over);

//graphics instantiation
graphics graph(clk_25mhz, rst, video_on, pixel_x, pixel_y, paddle_x, ball_x, ball_y, blocks, game_over, vga_r, vga_g, vga_b);

assign VGA_HS = hsync;
assign VGA_VS = vsync;
assign VGA_R = vga_r;
assign VGA_G = vga_g;
assign VGA_B = vga_b;
assign VGA_BLANK_N = video_on;
assign VGA_SYNC_N = 1'b0;
assign VGA_CLK = clk_25mhz;

assign LEDR[0] = game_over;
assign LEDR[1] = frame_tick;
assign LEDR[9:2] = 8'b0;

endmodule
	