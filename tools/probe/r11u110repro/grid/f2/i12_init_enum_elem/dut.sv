typedef enum logic [1:0] {A,B,C,D} e_t;
module dut #(parameter type id_t = e_t, localparam type rt_t = id_t [1:0]) (output logic [3:0] o);
  rt_t x = '0;
  assign o = x;
endmodule
