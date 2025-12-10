module graphics(
input wire clk,
input wire rst,
input wire video_on,
input wire [9:0]x,
input wire [9:0]y,
input wire [9:0] paddle_x,
input wire [9:0] ball_x,
input wire [9:0] ball_y,
input wire [39:0] blocks,
input wire game_over,
output reg [7:0] vga_r,
output reg [7:0] vga_g,
output reg [7:0] vga_b);

parameter PADDLE_WIDTH = 70, PADDLE_HEIGHT = 10, PADDLE_Y = 450, BALL_SIZE = 8;

parameter BLOCK_WIDTH = 100,
				BLOCK_HEIGHT = 20,
				BLOCK_START_Y = 50,
				BLOCK_ROWS = 8,
				BLOCK_COLS = 5,
				BLOCK_SPACING_X = 20,
				BLOCK_SPACING_Y = 5;
				
parameter COLOR_BLACK = 24'h000000,
				COLOR_WHITE = 24'hFFFFFF,
				COLOR_PADDLE = 24'h00FF00,
				COLOR_BALL = 24'hFF0000,
				COLOR_BLOCK_0 = 24'hFF0000,
				COLOR_BLOCK_1 = 24'hFF8800,
				COLOR_BLOCK_2 = 24'hFFFF00,
				COLOR_BLOCK_3 = 24'h00FF00,
				COLOR_BLOCK_4 = 24'h0088FF,
				COLOR_BLOCK_5 = 24'h8800FF,
				COLOR_BLOCK_6 = 24'hFF00FF,
				COLOR_BLOCK_7 = 24'hFFFFFF;
				
reg [23:0] rgb_data;
wire paddle_on, ball_on;
reg block_on;
reg [23:0] block_color;

integer i, j;
integer block_x, block_y;

assign paddle_on = (x >= paddle_x && x < paddle_x + PADDLE_WIDTH && y >= PADDLE_Y && y < PADDLE_Y + PADDLE_HEIGHT);
assign ball_on = (x >= ball_x && x < ball_x + BALL_SIZE && y >= ball_y && y < ball_y + BALL_SIZE);

always @(*) begin
	block_on = 0;
	block_color = COLOR_WHITE;
	
	for (i=0; i < BLOCK_ROWS; i=i+1) begin
		for(j=0; j < BLOCK_COLS; j=j+1) begin
			if(blocks[i * BLOCK_COLS + j]) begin
				block_x = BLOCK_SPACING_X + j * (BLOCK_WIDTH + BLOCK_SPACING_X);
				block_y = BLOCK_SPACING_Y + i * (BLOCK_HEIGHT + BLOCK_SPACING_Y);
		
				if(x >= block_x && x < block_x + BLOCK_WIDTH && y >= block_y && y < block_y + BLOCK_HEIGHT) begin
					block_on = 1;
			
					case(i)
						0: block_color = COLOR_BLOCK_0;
						1: block_color = COLOR_BLOCK_1;
						2: block_color = COLOR_BLOCK_2;
						3: block_color = COLOR_BLOCK_3;
						4: block_color = COLOR_BLOCK_4;
						5: block_color = COLOR_BLOCK_5;
						6: block_color = COLOR_BLOCK_6;
						7: block_color = COLOR_BLOCK_7;
						default: block_color = COLOR_WHITE;
					endcase
				end
			end 
		end
	end
end


always @(*) begin
	if(!video_on) begin
		rgb_data = COLOR_BLACK;
	end
	else if(game_over) begin
		rgb_data = 24'h800000;
	end
	else if(ball_on) begin
		rgb_data = COLOR_BALL;
	end
	else if(paddle_on) begin
		rgb_data = COLOR_PADDLE;
	end
	else if(block_on) begin
		rgb_data = block_color;
	end
	else begin
		rgb_data = COLOR_BLACK;
	end
end

always @(posedge clk) begin
	if (rst) begin
		vga_r <= 8'b0;
		vga_g <= 8'b0;
		vga_b <= 8'b0;
	end
	else begin 
		vga_r <= rgb_data[23:16];
		vga_g <= rgb_data[15:8];
		vga_b <= rgb_data[7:0];
	end
end 

endmodule 