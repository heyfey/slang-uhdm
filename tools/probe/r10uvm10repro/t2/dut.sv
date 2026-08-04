package p;
  typedef int pkg_int_t;
  typedef enum { PA, PB } pkg_enum_t;

  class Inner;
    int x;
  endclass

  class C;
    typedef int my_int_t;
    typedef enum { CA, CB } my_enum_t;
    typedef struct { int a; } my_struct_t;
    typedef Inner inner_t;

    function my_int_t f1();
      my_int_t l1;
      return l1;
    endfunction
    function my_enum_t f2();
      my_enum_t l2;
      return l2;
    endfunction
    function inner_t f3();
      inner_t l3;
      return l3;
    endfunction
    function my_struct_t f4();
      my_struct_t l4;
      return l4;
    endfunction
    function pkg_int_t f5();
      pkg_int_t l5;
      return l5;
    endfunction
    function pkg_enum_t f6();
      pkg_enum_t l6;
      return l6;
    endfunction
    function Inner f7();
      Inner l7;
      return l7;
    endfunction
  endclass
endpackage

module top;
  initial begin
  end
endmodule
