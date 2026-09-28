// (r11u191 const_cast_signext) which constant function calls Surelog folds in a continuous assignment: cast, member, system call
module top (output logic [7:0] o1, output logic [11:0] o2, output logic [31:0] o3, output logic [31:0] o4, output logic [7:0] o5);
  typedef logic signed [31:0] imm_t;
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  function automatic logic [7:0]  f1(logic [11:0] x); f1 = 8'(x);          endfunction
  function automatic logic [11:0] f3(op_t op);        f3 = op.f;           endfunction
  function automatic logic [31:0] f4(logic [11:0] x); f4 = $signed(x);     endfunction
  function automatic imm_t        f5(logic [11:0] x); f5 = imm_t'(x);      endfunction
  function automatic logic [7:0]  f6(logic [11:0] x); f6 = x[7:0];         endfunction
  localparam op_t OP = '{hi:'0, f: 12'h800};
  assign o1 = f1(12'hABC);
  assign o2 = f3(OP);
  assign o3 = f4(12'h800);
  assign o4 = f5(12'h800);
  assign o5 = f6(12'hABC);
endmodule
