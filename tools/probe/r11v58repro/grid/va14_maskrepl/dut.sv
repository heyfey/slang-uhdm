// v11u58 va14 — MASKING AND A REPLICATION ELEMENT, inside the TAGGED (bailed)
// state.  The 128-bit member W forces the walk to end there, so golden's
// elaborated listing stays tagged and every earlier cell is readable.
//   L : a literal 300 into an 8-bit member — does the producer MASK the value
//       as well as re-size it?  (`adjustUnsized` writes only an unsized '1.)
//   RP: a REPLICATION operation into a 16-bit member — stamped, and does the
//       walk continue past it?
package pk;
  typedef struct packed {
    logic [7:0]   L;   // 300           -> 8 ?
    logic [15:0]  RP;  // {2{8'd1}}     -> 16 ?
    int unsigned  C;   // unsigned'(64) -> 32 ?
    logic [127:0] W;   // 128'(0)       -> 128, then the walk returns
    int unsigned  Z;   // unsigned'(64) -> stays 64
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.C;
    r.G = (c.L > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ L: 300, RP: {2{8'd1}}, C: unsigned'(64),
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
