module traffic_light_controller (
    input  logic       clk,
    input  logic       reset,
    input  logic       TAORB, // True: Traffic at A, False: Traffic at B
    output logic [1:0] LA,    // 00: Green, 01: Yellow, 10: Red 
    output logic [1:0] LB
);

    // State Encoding
    typedef enum logic [1:0] {
        S0 = 2'b00, // LA Green, LB Red
        S1 = 2'b01, // LA Yellow, LB Red
        S2 = 2'b10, // LA Red, LB Green
        S3 = 2'b11  // LA Red, LB Yellow
    } state_t;

    state_t current_state, next_state;
    logic [2:0] timer; // 3-bit counter to count up to 5

    // Light Color Parameters
    localparam GREEN  = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED    = 2'b10;

    // --- State Register & Timer Logic ---
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
            timer <= 3'd0;
        end else begin
            current_state <= next_state;
            
            // Increment timer during yellow states, otherwise reset
            if (current_state == S1 || current_state == S3) begin
                if (current_state != next_state) 
                    timer <= 3'd0; // Reset timer on transition
                else
                    timer <= timer + 3'd1;
            end else begin
                timer <= 3'd0;
            end
        end
    end

    // --- Next State Logic ---
    always_comb begin
        next_state = current_state; // Default hold
        case (current_state)
            S0: begin
                if (!TAORB) next_state = S1;
            end
            S1: begin
                if (timer >= 3'd5) next_state = S2;
            end
            S2: begin
                if (TAORB) next_state = S3;
            end
            S3: begin
                if (timer >= 3'd5) next_state = S0;
            end
        endcase
    end

    // --- Output Logic ---
    always_comb begin
        // Default Safety State
        LA = RED;
        LB = RED;
        case (current_state)
            S0: begin LA = GREEN;  LB = RED;    end
            S1: begin LA = YELLOW; LB = RED;    end
            S2: begin LA = RED;    LB = GREEN;  end
            S3: begin LA = RED;    LB = YELLOW; end
        endcase
    end

endmodule