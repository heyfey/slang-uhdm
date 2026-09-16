// r11u49 arm a8 -- the same PACKED member select, but read from a PROCEDURAL
// expression inside the package (a function body) rather than a typedef dim.
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t PS = '{CTL:0, DAT:8};
  function automatic int unsigned f(); return PS.DAT; endfunction
endpackage
module a8 (output logic [31:0] o);
  assign o = p::f();
endmodule
