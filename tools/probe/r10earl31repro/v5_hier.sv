// r10earl31 VERIFIER arm v5 — THE UNTESTED EDGE OF THE NEW FULLNAME BRANCH.
//
// The shipped hier_path branch builds `prefix + "." + select.fullname + "." +
// select.name` with NO "prefix already present" guard (the pre-existing arm at
// ExprEmit.cpp ~5150 has one: `fn9.compare(0, prefix.size(), prefix) != 0`).
// Every measured hier_path cell in e1/e4 has an UNSCOPED select fullname
// (`dmi_req_i.data[4'h2 - 1:0]`), so the missing guard is never exercised there.
// A PORT-CONNECTION select is the case where our part_select fullnames come out
// already scoped (`work@v1.u1.a.d`, v1 arm cell v8) — so put a hier_path struct
// member select in a port connection and see whether the branch doubles.
package pk;
  localparam logic [3:0] DC = 4'h2;
  typedef struct packed { logic [7:0] lo; logic [7:0] hi; } inner_t;
  typedef struct packed { inner_t a; logic [15:0] b; } outer_t;
endpackage

module v5sub (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule

module v5 (
  input  pk::outer_t  o,
  output logic [31:0] y
);
  logic [31:0] w1, w2;
  v5sub u1 (.a(32'(o.a[pk::DC-1:0])), .b(w1));   // hier_path select in a port conn
  always_comb w2 = 32'(o.a[pk::DC-1:0]);         // the same select in a process
  assign y = w1 ^ w2;
endmodule
