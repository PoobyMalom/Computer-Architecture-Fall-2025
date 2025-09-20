// Blink RGB

module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
    parameter BLINK_INTERVAL = 2000000;
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    logic [2:0] color_state = 3'b000;


    initial begin
        RGB_R = 1'b0;
        RGB_G = 1'b0;
        RGB_B = 1'b0;
    end

    // Control loop and color decision
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            color_state <= color_state + 1;
        end
        else begin
            count <= count + 1;
        end
    end

    // Color based on color_state
    always_comb begin
      RGB_R = 1'b0;
      RGB_G = 1'b0;
      RGB_B = 1'b0;

      case (color_state)
        3'b000: begin // RED
          RGB_R = 1'b1; 
          RGB_G = 1'b0;
          RGB_B = 1'b0;
        end
        3'b001: begin // YELLOW
          RGB_R = 1'b1; 
          RGB_G = 1'b1;
          RGB_B = 1'b0;
        end
        3'b010: begin // GREEN
          RGB_R = 1'b0; 
          RGB_G = 1'b1;
          RGB_B = 1'b0;
        end
        3'b011: begin // CYAN
          RGB_R = 1'b0; 
          RGB_G = 1'b1;
          RGB_B = 1'b1;
        end
        3'b100: begin // BLUE
          RGB_R = 1'b0; 
          RGB_G = 1'b0;
          RGB_B = 1'b1;
        end
        3'b101: begin // MAGENTA
          RGB_R = 1'b1; 
          RGB_G = 1'b0;
          RGB_B = 1'b1;
        end
      endcase
    end

endmodule
