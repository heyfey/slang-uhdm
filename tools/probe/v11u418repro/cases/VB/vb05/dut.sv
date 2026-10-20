// § tdMoveRenamesBitSelect418
module m #(parameter int P[2:0] = '{5, 4, 1}) (input logic a, output logic [7:0] o);
  typedef struct packed { logic [P[1]-1:0] c; } h_s;
  function automatic h_s mk(); return '0; endfunction
  assign o = 8'(mk());
endmodule
module top; logic [7:0] o; m u (.a(1'b0), .o(o)); endmodule
