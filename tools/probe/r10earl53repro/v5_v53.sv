// r10earl53 VERIFIER arm v5 — the ESCAPED-IDENTIFIER ROOT, the trap that
// § connPathRootTs53's `nm.substr(0, nm.find_first_of(".["))` walks into.
//
// An escaped identifier MAY CONTAIN `.` and `[`.  `\pin.i .rd` prints as
// `hier_path: (pin.i.rd)` and its ROOT is the symbol named `pin.i`.  Splitting
// the printed text at the first `.` asks for `pin`.
//
//   u_esc   : escaped root, NO decoy  -> the split DECLINES (silent loss)
//   u_dec   : escaped root, a REAL symbol called `pin` in the SAME connection
//             -> the split ANSWERS WITH THE WRONG STRUCT (a mis-bind, the very
//                failure the helper's own comment says a name map "cannot" do)
//   u_brk   : escaped root containing `[`  (`\arr[0] .rd`)
package q53;
  typedef struct packed { logic rd; logic [7:0] addr; } req_t;
  typedef struct packed { logic [3:0] w; logic [3:0] x; } dec_t;
endpackage

module ch53 (input logic [7:0] d, output logic [7:0] q);
  assign q = d;
endmodule

module v5_v53 (
  input  q53::req_t \pin.i ,
  input  q53::req_t \arr[0] ,
  input  q53::dec_t pin,          // the DECOY: really called `pin`
  output logic [23:0] z_o
);
  logic [7:0] n_esc, n_dec, n_brk;
  // escaped root with a dot, no decoy in this connection
  ch53 u_esc (.d(\pin.i .addr),                 .q(n_esc));
  // escaped root with a dot, WITH a decoy named `pin` in the SAME connection
  ch53 u_dec (.d(\pin.i .addr | {4'b0, pin.w}), .q(n_dec));
  // escaped root containing a bracket
  ch53 u_brk (.d(\arr[0] .addr),                .q(n_brk));
  assign z_o = {n_esc, n_dec, n_brk};
endmodule
