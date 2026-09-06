// r10v167 arm I - the OTHER linked4==false gate, and it is LEGAL SV: a bare
// call to an INHERITED base-class method (inheritedNoBind9) with NAMED
// association skipping a middle formal, written CLEAN and written SHELLED.
package pi167;
  class basei167;
    int r;
    function int inh167(int a, int b = 0, int c = 0);
      return a + b + c;
    endfunction
    function int inz167(int a, int b = 77, int c = 88);
      return a + b + c;
    endfunction
    task inht167(int a, int b = 0);
      r = a + b;
    endtask
  endclass
  class kidi167 #(type T167 = int) extends basei167;
    int q;
    task goI();
      q = inh167(1);
      q = inh167(.a(1), .c(9));
      q = inz167(.a(1), .c(9));
      q = inh167(T167::nm167);
      q = inh167(.a(T167::nm167), .c(9));
      q = inh167(.c(9), .a(T167::nm167));
      q = inz167(.a(T167::nm167), .c(9));
      inht167(T167::nm167);
    endtask
  endclass
endpackage
