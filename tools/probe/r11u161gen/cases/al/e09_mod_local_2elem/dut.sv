// § r11u161 alias face (from r11u152repro/cases/EA/e03_local_alias)
module top(output logic [3:0] o);
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
  tx_t [1:0] w;
  assign w[0] = On;
  assign w[1] = On;
  assign o = w[0];
endmodule
