// § undefaultedPlaceholderRetry440
interface ifc #(parameter fn) ();
  integer f;
  initial f = $fopen(fn);
endinterface
module top; endmodule
