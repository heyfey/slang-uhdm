// § tfArgClassMethodOrder176
package pa;
  typedef enum logic [1:0] {A0, A1} e_t;
  class ka; function void m(e_t v); endfunction endclass
endpackage
package pb;
  typedef enum logic [2:0] {B0, B1, B2} e_t;
  class kb; function void m(e_t v); endfunction
    static function void s(e_t w); endfunction endclass
endpackage
module top;
  pa::ka a; pb::kb b;
  initial begin a = new; b = new; a.m(pa::A1); b.m(pb::B2); pb::kb::s(pb::B0); end
endmodule
