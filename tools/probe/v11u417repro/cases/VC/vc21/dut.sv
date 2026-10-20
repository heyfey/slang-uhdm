// § foreachArrayNamesClass417
class b;
  int v;
endclass
function automatic int uf();
  int b[3];
  int n;
  foreach (b[i]) n += i;
  return n;
endfunction
module top;
  int n;
  initial n = uf();
endmodule
