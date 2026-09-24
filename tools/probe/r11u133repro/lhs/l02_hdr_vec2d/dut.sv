// § impPaLhsDisjointClone133
package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module aes_cipher_core import aes_pkg::*;
   #(parameter logic [7:0][3:0] P = X)
   (output int a);
   assign a = X;
endmodule
module top(output int o);
   aes_cipher_core u_aes_cipher_core(.a(o));
endmodule
