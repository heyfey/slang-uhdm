// r10v167 arm B - RECEIVER-LESS faces: package function, in-class bare call,
// task, zero-formal, written-but-empty slot.  package-class home.
package pb167;
  function int bf167(int a, int b = 2, int c = 5);
    return a + b + c;
  endfunction
  task bt167(int a, int b = 4);
  endtask
  function int bz167();
    return 1;
  endfunction

  class shB167 #(type T167 = int);
    int r;
    function int im167(int a, int b = 6, int c = 8);
      return a + b + c;
    endfunction
    task it167(int a, int b = 9);
    endtask
    task cleanB();
      r = bf167(1);
      r = bf167(.a(1), .c(9));
      r = bf167(.c(9), .a(1));
      bt167(1);
      r = im167(1);
      r = im167(.a(1), .c(9));
      r = im167(.c(9), .a(1));
      it167(1);
      r = bz167();
      r = bf167(1, 2, );
    endtask
    task shellB();
      r = bf167(T167::nm167);
      r = bf167(.a(T167::nm167), .c(9));
      r = bf167(.c(9), .a(T167::nm167));
      bt167(T167::nm167);
      r = im167(T167::nm167);
      r = im167(.a(T167::nm167), .c(9));
      r = im167(.c(9), .a(T167::nm167));
      it167(T167::nm167);
      r = bf167(T167::nm167, 2, );
      r = bf167(1, T167::nm167, );
    endtask
  endclass
endpackage
