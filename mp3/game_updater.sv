
module updater (
  input  logic       clk,
  input  logic       start_next_game_state, // Flag from controller telling us data has been displayed
  input  logic [7:0] cell_state,            // Incoming data from memory during READ phase
  output logic       done_writing,
  output logic [5:0] address,               // Address we are reading/writing from
  output logic [7:0] next_cell_state,       // Outgoing data during WRITE
  output logic       start_writing          // Flag to memory to write
);

  // Board State Memory, stored in a flat 64 bit register
  reg board_state       [0:63]; 
  reg next_board_state  [0:63];

  // State machine states
  localparam READ          = 2'b00;
  localparam WRITE         = 2'b01;
  localparam CALC          = 2'b10;
  localparam IDLE          = 2'b11;

  logic [1:0] state        = IDLE;
  logic [1:0] next_state;

  // Counters for READ/WRITE phases
  logic [2:0] i            = 3'b0;
  logic [2:0] j            = 3'b0;

  // Address to use internally and assigning the exposed address
  logic [5:0] board_address = 6'd0;
  assign address = board_address;

  // Counters for CALC phase
  logic [2:0] i_calc            = 3'b0;
  logic [2:0] j_calc            = 3'b0;

  // Number of neighbors for each cell
  logic [3:0] neighbors         = 4'b0;

  // Temps for wrap arounds
  logic [2:0] left_col;
  logic [2:0] right_col;
  logic [2:0] bottom_row;
  logic [2:0] top_row;

  // Previous state for state entry detection
  logic [1:0] prev_state;
  always_ff @(posedge clk) begin
    prev_state <= state;
  end

  wire start_read   = (state == READ)  && (prev_state != READ);
  wire start_calc   = (state == CALC)  && (prev_state != CALC);
  wire start_write  = (state == WRITE) && (prev_state != WRITE);
  wire write        = (state == WRITE) && (prev_state == WRITE);

  assign start_writing = write;
  assign done_calculating = ((i_calc == 3'b111) && (j_calc == 3'b111));
  assign done_writing = (state == IDLE)  && (prev_state != IDLE);

  always_comb begin
    next_state = 2'bx;
    unique case (state)
      IDLE:
        if (start_next_game_state)
          next_state = READ;
        else
          next_state = IDLE;
      READ:
        if (board_address == 6'd63)
          next_state = CALC;
        else
          next_state = READ;
      CALC:
        if (done_calculating)
          next_state = WRITE;
        else
          next_state = CALC;
      WRITE:
        if (board_address == 6'd63)
          next_state = IDLE;
        else
          next_state = WRITE;
      
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
      state <= next_state;
  end

  always_ff @(posedge clk) begin
    if (start_read || start_write) begin 
      i             <= 3'd0;
      j             <= 3'd0;
      board_address <= 6'd0;
    end else if ((state == READ) || (state == WRITE)) begin
      if (i == 3'd7) begin
        i <= 3'd0;
        if (j == 3'd7)
          j <= 3'd0;
        else
          j <= j + 1;
      end
      else begin
        i <= i + 1;
      end

      board_address <= board_address + 1;
    end
  end

  always_ff @(posedge clk) begin
    if (state == READ) begin
      board_state[board_address] <= (cell_state != 8'd0);
    end
  end

  logic temp_cell_next_state;
  logic temp_cell_state;
  logic inside_dead_cell_case;

  // always_ff @(posedge clk) begin
  //   if (state == CALC) begin
  //     if (i_calc == 3'd7) begin
  //       j_calc <= j_calc + 1;
  //       i_calc <= 0;
  //       end else begin
  //         i_calc <= i_calc + 1;
  //     end
  //   end
  // end

  always_ff @(posedge clk) begin
    if (start_calc) begin
      i_calc <= 3'd0;
      j_calc <= 3'd0;
    end else if (state == CALC) begin
      left_col   = (i_calc == 3'd0) ? 3'd7 : (i_calc - 3'd1);
      right_col  = (i_calc == 3'd7) ? 3'd0 : (i_calc + 3'd1);
      top_row    = (j_calc == 3'd0) ? 3'd7 : (j_calc - 3'd1);
      bottom_row = (j_calc == 3'd7) ? 3'd0 : (j_calc + 3'd1);

      neighbors =  board_state[(top_row    * 8) + left_col ] + 
                   board_state[(top_row    * 8) + i_calc   ] + 
                   board_state[(top_row    * 8) + right_col] + 
                   board_state[(j_calc     * 8) + left_col ] + 
                   board_state[(j_calc     * 8) + right_col] + 
                   board_state[(bottom_row * 8) + left_col ] + 
                   board_state[(bottom_row * 8) + i_calc   ] + 
                   board_state[(bottom_row * 8) + right_col];

      // neighbors =  board_state[(left_col  * 8) + top_row   ] + // Top Left Cell
      //              board_state[(i_calc    * 8) + top_row   ] + // Top Middle Cell
      //              board_state[(right_col * 8) + top_row   ] + // Top Right Cell
      //              board_state[(left_col  * 8) + j_calc    ] + // Middle Left Cell
      //              board_state[(right_col * 8) + j_calc    ] + // Middle Right Cell
      //              board_state[(left_col  * 8) + bottom_row] + // Bottom Left Cell
      //              board_state[(i_calc    * 8) + bottom_row] + // Bottom Middle Cell
      //              board_state[(right_col * 8) + bottom_row];  // Bottom Right Cell


      temp_cell_state <= (board_state[(j_calc * 8) + i_calc]);
      if ((board_state[(j_calc * 8) + i_calc] == 1'b0) && (neighbors == 4'd3)) begin
        next_board_state[(j_calc * 8) + i_calc] <= 1'b1;
        temp_cell_next_state <= 1'b1;
        inside_dead_cell_case <= 1'b1;
      end 
      else if (board_state[(j_calc * 8) + i_calc] == 1'b1) begin
        inside_dead_cell_case <= 1'b0;
        if ((neighbors < 4'd2) || (neighbors > 4'd3)) begin
          next_board_state[(j_calc * 8) + i_calc] <= 1'b0;
          temp_cell_next_state <= 1'b0;
        end else begin
          next_board_state[(j_calc * 8) + i_calc] <= 1'b1;
          temp_cell_next_state <= 1'b1;
        end
      end
      else begin
        next_board_state[(j_calc * 8) + i_calc] <= 1'b0;
        temp_cell_next_state <= 1'b0;
        inside_dead_cell_case <= 1'b0;
      end

      if (i_calc == 3'd7) begin
        j_calc <= j_calc + 1;
        i_calc <= 0;
        end else begin
          i_calc <= i_calc + 1;
      end
    end
  end

  wire cell_next_alive;
  assign cell_next_alive = next_board_state[(j * 8) + i];
  assign next_cell_state = cell_next_alive ? 8'b0000_1111 : 8'b0000_0000;  

endmodule