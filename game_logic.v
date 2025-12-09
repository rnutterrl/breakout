module game_logic(
input wire clk,
input wire rst,
input wire frame_tick,
input wire [3:0] paddle_control,
output reg [9:0] paddle_x,
output reg [9:0] ball_x,
output reg [9:0] ball_y,
output reg [39:0] blocks,
output reg game_over);

parameter SCREEN_WIDTH = 640;
parameter SCREEN_HEIGHT = 480;

//paddle parameters
parameter PADDLE_WIDTH = 70, 
		PADDLE_HEIGHT = 10,
		PADDLE_Y = 450,
		PADDLE_SPEED = 5;
		
//ball parameters
parameter BALL_SIZE = 8,
		BALL_SPEED_X = 2,
		BALL_SPEED_Y = 2;
		
//block parameters
parameter BLOCK_WIDTH = 120,
		BLOCK_HEIGHT = 20,
		BLOCK_START_Y = 50,
		BLOCK_ROWS = 8,
		BLOCK_COLS = 5,
		BLOCK_SPACING_X = 8,
		BLOCK_SPACING_Y = 5;
		
//reg signed will counter in negative numbers
reg signed [10:0] ball_vx;
reg signed [10:0] ball_vy;

reg game_started;

integer i, j;
reg [9:0] block_x, block_y;

always @(posedge clk) begin
	if (rst) begin
			paddle_x <= (SCREEN_WIDTH - PADDLE_WIDTH)/2; //rst paddle to middle of screen
			ball_x <= SCREEN_WIDTH/2;
			ball_y <= SCREEN_HEIGHT/2;
			ball_vx <= BALL_SPEED_X;
			ball_vy <= BALL_SPEED_Y;
			game_over <= 0;
			game_started <= 0;
			blocks <= 40'hFFFFFFFFFF;
			
		end
		else if(frame_tick && !game_over) begin
			if(!game_started && paddle_control[0])
				game_started <= 1;
				
			if(game_started)begin
				if(paddle_control[1] && paddle_x > 0)
					paddle_x <= paddle_x - PADDLE_SPEED;
				else if (paddle_control[2] && paddle_x < (SCREEN_WIDTH - PADDLE_WIDTH))
					paddle_x <= paddle_x + PADDLE_SPEED;
				
					//ball position update
					ball_x <= ball_x + ball_vx;
					ball_y <= ball_y + ball_vy;
					
					//collision control
					if(ball_x <= 0 || ball_x >= (SCREEN_WIDTH - BALL_SIZE))
						ball_vx <= -ball_vx;
					if(ball_y <= 0)
						ball_vy <= -ball_vy;
						
					if(ball_y + BALL_SIZE >= PADDLE_Y && 
						ball_y + BALL_SIZE <= PADDLE_Y + PADDLE_HEIGHT && 
						ball_x + BALL_SIZE >= paddle_x && 
						ball_x <= paddle_x + PADDLE_WIDTH) begin
						ball_vy <= -BALL_SPEED_Y;
						ball_y <= PADDLE_Y - BALL_SIZE;
					end
					
					for(i=0; i< BLOCK_ROWS; i=i+1) begin
						for(j=0; j < BLOCK_COLS; j=j+1) begin
							if(blocks[i*BLOCK_COLS + j]) begin
								block_x <= BLOCK_SPACING_X + j *(BLOCK_WIDTH + BLOCK_SPACING_X);
								block_y <= BLOCK_SPACING_Y + i *(BLOCK_HEIGHT + BLOCK_SPACING_Y);
								
								if(ball_x + BALL_SIZE >= block_x && ball_x <= block_x + BLOCK_WIDTH && ball_y + BALL_SIZE >= block_y && ball_y <= block_y + BLOCK_HEIGHT) begin 
								blocks[i*BLOCK_COLS + j] <= 0;
								ball_vy <= -ball_vy;
							end
						end
					end
				end 
					
					if(ball_y >= SCREEN_HEIGHT)
						game_over <= 1;
					end
				end
			end
endmodule 
