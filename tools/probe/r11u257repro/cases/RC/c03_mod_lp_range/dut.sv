// § genLpFoldLeftOperandSpan257 (control: a module-level localparam keeps its symbolic bound)
module common #(parameter int AW = 8)(output logic [AW-1:0] o);
  localparam bit [AW-1:0] S = AW'(4);
  assign o = S;
endmodule
module top; logic [7:0] o; common u(.o(o)); endmodule
