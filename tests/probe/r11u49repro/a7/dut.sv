// r11u49 arm a7 -- POSITIVE CONTROL for the landed PACKED member-select
// trigger, alone: one packed-struct package localparam read only through a
// member select inside the package (a typedef's packed dimension).
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t PS = '{CTL:0, DAT:8};
  typedef struct packed { logic [PS.DAT-1:0] w; } req_t;
endpackage
module a7 (output logic [31:0] o);
  p::req_t r;
  assign o = r.w;
endmodule
