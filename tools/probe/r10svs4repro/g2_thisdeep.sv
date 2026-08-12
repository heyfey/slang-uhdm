// r10svs4repro/g2_thisdeep.sv — grid arm 2: the this-rooted select shapes that
// reach the OTHER hier_path call sites, so the law is measured at every site it
// will be written at rather than at one.
//
//   * select-THEN-member   (this.st[k].fld)   -> emitMixedHierPath
//   * member-member-select (this.h.data[k])   -> the `chain` branch, 2 members
//   * super-rooted select  (super.data[k])    -> is the law the `this` KEYWORD
//                                               or ANY implicit-self keyword?
//   * bit-within-element   (this.data[k][3])  -> nested-select branch
//   * part select          (this.data[k][3:0])
//   * method-call receiver (this.data.size()) -> the parens-less/builtin arm
//
// One statement per line; the line number in the dump names the cell.
typedef struct packed { byte fld; byte g2; } st_t;

class Base;
   byte data[];
   function void bump(); endfunction
endclass

class Holder;
   byte data[];
endclass

class Deep extends Base;
   st_t   st[4];
   Holder h;
   int    r;

   function void f(int k);
      r = this.st[k].fld;                  // d1  select-THEN-member, this
      r = this.h.data[k];                  // d2  member.member[idx], this
      r = super.data[k];                   // d3  SUPER-rooted select
      r = this.data[k][3];                 // d4  bit within the element, this
      r = this.data[k][3:0];               // d5  part select, this
      r = this.data.size();                // d6  method call on a this member
      r = this.st[2].fld;                  // d7  select-THEN-member, const idx
      this.st[k].fld = 8'h1;               // d8  LVALUE select-then-member
      this.h.data[k] = 8'h2;               // d9  LVALUE member.member[idx]
   endfunction
endclass

class Other;
   st_t   st[4];
   Holder h;
   byte   data[];
   int    r;
   function void g(Other o, int k);
      r = o.st[k].fld;                     // d10 select-THEN-member, HANDLE
      r = o.h.data[k];                     // d11 member.member[idx], HANDLE
      r = o.data[k][3];                    // d12 bit within element, HANDLE
      o.st[k].fld = 8'h3;                  // d13 LVALUE, HANDLE
   endfunction
endclass

module m2;
   initial begin end
endmodule
