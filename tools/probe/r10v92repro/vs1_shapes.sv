package sp;
  typedef struct packed { logic [3:0] m1; logic [3:0] m2; } inner_t;
  typedef struct packed { inner_t a; inner_t b; } st_t;
endpackage
module sleaf (input logic [7:0] i, output logic [7:0] o);
  logic [7:0] arr;
  logic [3:0] mem [0:3];
  assign arr = i;
  assign o = arr;
endmodule
module s1 #(parameter bit EN = 1) (
    input sp::st_t s, input logic [15:0] w, output logic [7:0] y1,
    output logic y2, output logic y3, output logic y4, output logic y5,
    output logic y6, output logic [3:0] y7, output logic y8);
  logic [3:0] mem [0:3];
  logic [3:0] mem2 [0:1][0:1];
  logic [7:0] so;
  sleaf u (.i(w[7:0]), .o(so));
  assign y1 = EN ? mem[1]        : 8'h0;  // esel over plain unpacked name
  assign y2 = EN ? mem[1][0]     : 1'b0;  // esel over esel
  assign y3 = EN ? mem2[0][1][0] : 1'b0;  // esel over esel over esel
  assign y4 = EN ? s.a.m1[0]     : 1'b0;  // esel over member (2 deep)
  assign y5 = EN ? u.arr[0]      : 1'b0;  // esel over hier
  assign y6 = EN ? u.mem[1][0]   : 1'b0;  // esel over esel over hier
  assign y7 = EN ? w[7:4]        : 4'h0;  // range over plain -> part_select
  assign y8 = EN ? w[3]          : 1'b0;  // esel over plain packed
endmodule
