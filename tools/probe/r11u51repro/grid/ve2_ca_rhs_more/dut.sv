// VERIFIER arm (r11v51) — ROAD E.  The map's brief names one predicate for our
// emitter: "the Rhs is a constant-valued read of a parameter's FIELD (a
// MemberAccessExpression chain bottoming on a Parameter)".  The producer site
// it cites (UhdmWriter.cpp:2245) is blind to the Rhs kind and reduces whatever
// it is handed.  Those two disagree on every Rhs that CONTAINS a field read
// without BEING one.  Cut them, and cut the nested / array / generate cells the
// pass never reached.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } inner_t;
  typedef struct packed { inner_t sub; int unsigned k; } outer_t;
  localparam inner_t LIT  = '{n: 3, base: 64'h1000};
  localparam outer_t OUT  = '{sub: '{n: 5, base: 64'h2000}, k: 9};
  typedef int unsigned iarr_t [2];
  localparam iarr_t ARR = '{11, 12};
endpackage
module dut #(parameter p::inner_t CFG = p::LIT,
             parameter p::outer_t OC  = p::OUT,
             parameter p::iarr_t  AP  = p::ARR)
           (input logic [31:0] a_i,
            output logic [31:0] o_op, output logic [31:0] o_nest,
            output logic [31:0] o_arr, output logic [31:0] o_gen,
            output logic [31:0] o_cat, output logic [31:0] o_mix,
            output logic [31:0] o_ctl);
  assign o_op   = CFG.n + 1;              // operation CONTAINING a field read
  assign o_nest = OC.sub.n;               // two-level field read
  assign o_arr  = AP[0];                  // unpacked-array parameter element
  assign o_cat  = {16'h0, CFG.n[15:0]};   // concat containing a field read
  assign o_mix  = CFG.n + a_i;            // field read + a NON-constant (control)
  assign o_ctl  = a_i;                    // non-constant (control)
  if (1) begin : g
    assign o_gen = CFG.n;                 // the plain field read inside a GENERATE
  end
endmodule
