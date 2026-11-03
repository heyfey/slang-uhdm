// § caReduceLeavesOpKept475
// two levels down: a grandchild reads its parent's override
module leaf #(parameter int A = 1)(output logic [7:0] y);
  assign y = A ^ 8'hf0;
endmodule
module mid #(parameter int B = 2)(output logic [7:0] y);
  leaf #(.A(B + 1)) l(y);
endmodule
module top(output logic [7:0] y);
  mid #(.B(5)) m(y);
endmodule
