//https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm - 14/1/25
module LDU #(parameter SIZE = 7) (output logic [SIZE-1:0] xOut, yOut,
								output logic is_drawing, busy,
								input logic [SIZE-1:0] x0, x1, y0, y1,
								input logic start, clk, reset);

logic signed [SIZE+2:0] D;
logic signed [SIZE+1:0] da, db;
logic [SIZE-1:0] a0, a1, b0, b1;
logic inverted_axis, b_increment;

enum {idle, setupAxis, setupPoints, setupIncrement, drawing, waiting} state;

assign busy = (state != idle);
assign is_drawing = (state == setupIncrement || state == drawing || state == waiting) ? '1 : '0;
assign xOut = inverted_axis ? b0 : a0;
assign yOut = inverted_axis ? a0 : b0;

always_ff @ (posedge clk, posedge reset)
	if (reset)
	begin
		da <= '0;
		db <= '0;
		D <= '0;
		a0 <= '0;
		a1 <= '0;
		b0 <= '0;
		b1 <= '0;
		b_increment <= '1;
		inverted_axis <= '0;
	end
	else case(state)
		idle : if (start) begin
			state <= setupAxis; //Initiates setup phase and ensures x0 < x1 (flips coords if false)
			
			da <= x1 - x0;
			db <= y1 - y0;
			a0 <= x0;
			a1 <= x1;
			b0 <= y0;
			b1 <= y1;
			D <= '0;
			b_increment <= '1;
			inverted_axis <= '0;
		end
		
		setupAxis : begin
			if ((db[SIZE] ? -db : db) > (da[SIZE] ? -da : da))
			begin
				inverted_axis <= '1;
				a0 <= b0;
				a1 <= b1;
				b0 <= a0;
				b1 <= a1;
				da <= db;
				db <= da;
			end
			
			state <= setupPoints;
		end
		
		setupPoints : begin
			if (da < 0)
			begin
				a0 <= a1;
				a1 <= a0;
				b0 <= b1;
				b1 <= b0;
				da <= -da;
				db <= -db;
			end
			
			state <= setupIncrement;
		end
		
		setupIncrement : begin
			if (db < 0)
			begin
				db <= -db;
				b_increment <= '0;
				D <= 2 * (-db) - da;
			end
			else 
				D <= 2 * db - da;
			
			state <= drawing;
		end

		drawing : begin
			if (a0 < a1)
			begin
				if (D > 0) //1 means negative thus D < 0
				begin
					if (b_increment) b0 <= b0 + 1;
					else b0 <= b0 - 1;
					
					D <= D + 2 * (db - da);
				end
				else
					D <= D + 2 * db;
				
				a0 <= a0 + 7'd1;
				
				state <= waiting;
			end
			else
				state <= idle;
		end
		
		waiting : state <= drawing;
	endcase
endmodule