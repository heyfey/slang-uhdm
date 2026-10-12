// § paramInitMemberSelLvShape294
// an unpacked struct parameter with an unpacked array member
package pk;
  typedef struct { int a; logic [7:0] d; int arr [3]; } u_t;
  localparam u_t U = '{a: 1, d: 8'h5, arr: '{4, 5, 6}};
endpackage
module kid #(parameter pk::u_t CFG = pk::U) (output logic [7:0] o);
  localparam int B = CFG.arr[1];
  localparam logic E = CFG.d[4];
  assign o = B + E;
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
