// r11u58 xd8 — WHERE the const-function call may stand.  Five identical
// package pattern localparams, each read whole as a call argument in exactly
// one HOLDER kind, so the law's boundary is measured rather than assumed.
//   S1 a module PARAMETER PORT default          (the witness's own holder)
//   S2 a module body LOCALPARAM
//   S3 a cont_assign
//   S4 a variable initialiser in an always_comb
//   S5 an instance PARAMETER OVERRIDE actual
package pk;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    logic [7:0]  D;
    logic [15:0] F;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  function automatic int unsigned pick(u_t c);
    return c.A;
  endfunction
  localparam u_t S1 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t S2 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t S3 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t S4 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t S5 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
endpackage
module sub #(parameter pk::r_t C = '{default:0}) (output logic [31:0] y);
  assign y = C.X;
endmodule
module dut #(parameter pk::r_t P = pk::build(pk::S1)) (output logic [31:0] o);
  localparam pk::r_t L2 = pk::build(pk::S2);
  logic [31:0] v;
  always_comb begin
    automatic int unsigned t = pk::pick(pk::S4);
    v = t;
  end
  sub #(.C(pk::build(pk::S5))) u5 (.y());
  assign o = P.X + L2.X + pk::pick(pk::S3) + v;
endmodule
