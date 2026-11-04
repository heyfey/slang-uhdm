// § pkgTsRefObjChainName134
module top(output logic [3:0] o);
   parameter int N = 4;
   parameter logic [N-1:0] A = '0;
   assign o = A;
endmodule
