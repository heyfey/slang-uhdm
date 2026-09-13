// r11u7 grid h5 — nested aggregate on a MODULE (not an interface) port-less
// instance and on a package/localparam holder, to bound the law's surface.
package q5;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}};
endpackage
module child #(parameter q5::cfg_t CFG = q5::CDEF) (output logic o);
  localparam int BYT = CFG.BUS.DAT/8;
  assign o = BYT[0];
endmodule
module top (output logic o);
  localparam q5::cfg_t LOC = '{BUS: '{DAT: 16}};
  child #(.CFG(q5::CDEF)) c0 (.o(o));
endmodule
