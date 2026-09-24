// r11u71 n3 — THE INTERFACE HOME.  `bindVariable`'s switch has no
// `uhdminterface_inst` case, so an interface body is SKIPPED and the walk goes
// on to the INSTANTIATING MODULE.  Three cells: a name that lives only in the
// interface (nothing found -> member width), a name that also lives in the
// instantiating module (found -> the module's width) and a module-side control.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] ifonly;
  logic [31:0] both;
  if (1) begin : gi
    logic [31:0] iflocal;     // declared in the interface GEN scope only
    assign ifonly  = C.n;     // interface-body target
    assign both    = C.n;     // also declared in the instantiating module
    assign iflocal = C.n;     // gen-local, nowhere else
  end
endinterface

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o);
  logic [15:0] both;          // the MODULE-side namesake, 16 bits
  ifc u_if ();
  if (1) begin : gm
    logic [31:0] mv;
    assign mv = CFG.n;        // CONTROL: a module gen scope
  end
  assign both = 16'd0;
  assign o = u_if.ifonly ^ u_if.both ^ u_if.gi.iflocal ^ gm.mv;
endmodule
