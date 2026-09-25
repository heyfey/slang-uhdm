// § genCaseItemUnnamed152
interface bus_if #(parameter int S = 1);
  logic a;
  case (S)
    1: begin
      assign a = 1'b1;
    end
    default: assign a = 1'b0;
  endcase
endinterface
module top(output logic o);
  bus_if b();
  assign o = b.a;
endmodule
