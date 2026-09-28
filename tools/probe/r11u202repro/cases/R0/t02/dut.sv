// § classTdRetSharesTypedefTs200
package p;
  class A; int x; endclass
  typedef A a_t;
  class H;
    a_t k;
    function a_t mk();
      return k;
    endfunction
    static function a_t smk();
      a_t z = new;
      return z;
    endfunction
  endclass
endpackage
module t02; endmodule
