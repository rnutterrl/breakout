module vga_controller(input wire clk, 
input wire rst,
output reg hsync, // horizontal sync
output reg vsync, // vertical sync 
output reg video_on,
output reg [9:0]x,
output reg [9:0]y); 

parameter TOTAL_WIDTH = 800;
parameter ACTIVE_WIDTH = 640;
parameter TOTAL_HEIGHT = 525;
parameter ACTIVE_HEIGHT = 480;

//control the duration between end of horizontal pulse and start of the next line
parameter H_BACK_PORCH = 48;
parameter H_FRONT_PORCH = 16;
parameter H_PULSES = 96;

//control the duration between end of vertical pulse and start of the next line
parameter V_BACK_PORCH = 33;
parameter V_FRONT_PORCH = 10;
parameter V_PULSES = 2; 

reg [9:0] h_count;
reg [9:0] v_count;

// Horizontal counter 
always @(posedge clk) begin 
	if (rst) begin
		h_count <= 10'b0;
	end 
	else begin
		if (h_count == TOTAL_WIDTH - 1) begin 
			h_count <= 10'b0;
		end 
		else begin 
			h_count <= h_count + 1'b1;
		end
	end
end 

//Vertical counter
always @(posedge clk) begin
	if (rst) begin
		v_count <= 10'b0;
	end 
	else begin 
		if(h_count == TOTAL_WIDTH - 1) begin
			if (v_count == TOTAL_HEIGHT - 1'b1) begin
				v_count <= 10'b0;
			end
			else begin 
				v_count <= v_count + 1'b1;
			end
		end
	end
end 

// creating hsysnc 
always @(posedge clk) begin 
	if (rst)
		hsync <= 1'b1;
	else 
	hsync <= (h_count >= (ACTIVE_WIDTH + H_FRONT_PORCH) && (h_count < ACTIVE_WIDTH + H_FRONT_PORCH + H_PULSES)) ? 0:1;
	end 
	
// creating vsysnc 
always @(posedge clk) begin 
	if (rst)
		vsync <= 1'b1;
	else 
	vsync <= (v_count >= (ACTIVE_HEIGHT + V_FRONT_PORCH) && (v_count < ACTIVE_HEIGHT + V_FRONT_PORCH + V_PULSES)) ? 0:1;
	end 
	

always @(posedge clk) begin
	if (rst)
		video_on <= 1'b0;
	else 
		video_on <= (h_count < ACTIVE_WIDTH) && (v_count < ACTIVE_HEIGHT);
	end 
	
always @(posedge clk) begin
	if (rst) begin 
		x <= 1'b0;
		y <= 1'b0;
	end else begin 
		x <= (h_count < ACTIVE_WIDTH) ? h_count : 0;
		y <= (v_count < ACTIVE_HEIGHT) ? v_count : 0;
	end
end
endmodule 