// § callFoldFormalBitSelLoc144
package pk;
  localparam logic [3:0] C = {1'b1, 3'b010};
endpackage
module top(output a, output b, output c);
   function automatic logic sel(int unused, logic [3:0] x);
      return x[3];
   endfunction
   assign a = sel(0,
                  4'b1000);
   assign b = sel(1, pk::C);
   assign c = sel(2, 'hF);
endmodule
