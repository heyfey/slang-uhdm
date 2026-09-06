// r10v167 arm A - METHOD faces (receiver-ful), package-class home.
// Every SHELLED cell has a CLEAN twin whose only difference is the bad
// argument T167::nm167 (a `::` read through a generic class's default
// specialization).
package pa167;
  class tgt167;
    int r;
    function int mf167(int a, int b = 7, int c = 0);
      return a + b + c;
    endfunction
    task mt167(int a, int b = 3);
      r = a + b;
    endtask
    function int zf167();
      return 5;
    endfunction
  endclass

  class shA167 #(type T167 = int);
    tgt167 h;
    int r;
    task cleanA();
      r = h.mf167(1, 7, 0);
      r = h.mf167(1);
      r = h.mf167(1, 9);
      r = h.mf167(.a(1), .c(9));
      r = h.mf167(.c(9), .a(1));
      r = h.mf167(1, .c(9));
      r = h.mf167(1, 2, );
      h.mt167(1);
      r = h.zf167();
    endtask
    task shellA();
      r = h.mf167(T167::nm167, 7, 0);
      r = h.mf167(T167::nm167);
      r = h.mf167(T167::nm167, 9);
      r = h.mf167(.a(T167::nm167), .c(9));
      r = h.mf167(.c(9), .a(T167::nm167));
      r = h.mf167(T167::nm167, .c(9));
      r = h.mf167(T167::nm167, 2, );
      h.mt167(T167::nm167);
      r = h.mf167(1, 7, T167::nm167);
      r = h.mf167(1, T167::nm167);
    endtask
  endclass
endpackage
