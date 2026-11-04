// § genLocalEnumConstShared184: an enum declared in a NESTED generate block (inner if inside an outer named block), read in the inner block's process
module top #(parameter int P = 1) (input logic clk, output logic [1:0] y);
  if (P > 0) begin : outer
    logic en;
    if (P == 1) begin : inner
      typedef enum logic [1:0] {IDLE, RUN, DONE} ph_e;
      ph_e st;
      always_ff @(posedge clk) begin
        case (st)
          IDLE: st <= RUN;
          RUN: st <= DONE;
          default: st <= IDLE;
        endcase
      end
      assign y = st;
    end
  end
endmodule
