// pacman location control module 
// keep track of pacman's current and next location on the game map
module pacman_loc_ctrl(CLOCK_50, reset, done, up, down, left, right, 
							  collision_type, pill_count,
							  curr_pacman_x, curr_pacman_y, next_pacman_x, 
							  next_pacman_y, ready);
    input logic CLOCK_50, reset, done; // done: from RAM write module that indicates curr position has been removed and next position has been write
    input logic up, down, left, right;
	 input logic [3:0] collision_type;
	 input logic [32:0] pill_count;
    output logic [5:0] curr_pacman_x, next_pacman_x;
    output logic [4:0] curr_pacman_y, next_pacman_y;
    output logic ready;
    enum {still, hold, move} ps, ns;

    logic [3:0] direction;
    assign direction = {up, down, left, right}; // should only be one hot


    always_latch begin
        case(ps)
            still: begin
                ready = 0;
                if (direction == 4'b0000) begin
                    ns = still;
                    next_pacman_x = curr_pacman_x;
                    next_pacman_y = curr_pacman_y;
                end
                else begin 
                    ns = hold;
                    if (up) begin
                        next_pacman_x = curr_pacman_x;
                        next_pacman_y = curr_pacman_y - 1;
                    end 
                    else if (down) begin
                        next_pacman_x = curr_pacman_x;
                        next_pacman_y = curr_pacman_y + 1;
                    end
                    else if (left) begin
                        next_pacman_x = curr_pacman_x - 1;
                        next_pacman_y = curr_pacman_y;
                    end
                    else if (right) begin
                        next_pacman_x = curr_pacman_x + 1;
                        next_pacman_y = curr_pacman_y;
                    end
                    else begin
                        next_pacman_x = 6'dx;
                        next_pacman_y = 5'dx;
                    end
                end
            end
            hold: begin
                ns = move;
            end
            move: begin
               if (done) ns = still;
               else ns = move;
                ready = 1;
                // block determining next pacman location based on if it is a valid move
                if (collision_type == 4'b0001) begin // collide with wall
                    next_pacman_x = curr_pacman_x;
                    next_pacman_y = curr_pacman_y;
                    end
                else begin
                    next_pacman_x = next_pacman_x;
                    next_pacman_y = next_pacman_y;
                    end
            end
        endcase
    end

    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            ps <= still;
            curr_pacman_x <= 6'd20;
            curr_pacman_y <= 5'd20;
        end 
        else begin
            ps <= ns;
            if (done) begin
                curr_pacman_x <= next_pacman_x;
                curr_pacman_y <= next_pacman_y;
            end
            else begin
                curr_pacman_x <= curr_pacman_x;
                curr_pacman_y <= curr_pacman_y;
            end
        end
    end
endmodule


// testbench for pacman_loc_ctrl module
module pacman_loc_ctrl_testbench();
    logic CLOCK_50, reset, done; // done: from RAM write module that indicates curr position has been removed and next position has been write
    logic up, down, left, right;
	 logic [3:0] collision_type;
	 logic [32:0] pill_count;
    logic [5:0] curr_pacman_x, next_pacman_x;
    logic [4:0] curr_pacman_y, next_pacman_y;
    logic [3:0] direction;
	parameter CLOCK_PERIOD = 100;

    assign {up, down, left, right} = direction;
    
    pacman_loc_ctrl dut (.*);

    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; done <= 0; direction <= 4'b0000; @(posedge CLOCK_50);
        direction <= 4'b1000; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0001; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        $stop;
    end
endmodule