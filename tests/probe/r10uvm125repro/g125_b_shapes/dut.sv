// r10uvm125 arm B — ARG SHAPES for a converting output/inout formal:
// bare ref, bit-select, part-select, indexed part-select, struct member,
// array element, hierarchical name, and a same-type control in each row.
package pk125b;
  typedef bit [63:0] wide_t;
  typedef struct packed { bit [31:0] f0; bit [31:0] f1; } pair_t;

  function automatic int fo(input int p, output wide_t v);
    v = 64'd1; return p;
  endfunction
  function automatic int fio(input int p, inout wide_t v);
    v = v + 1; return p;
  endfunction
  function automatic int fw(input int p, output bit [7:0] v);
    v = 8'd1; return p;
  endfunction

  class B125;
    bit [31:0] narr;
    bit [63:0] same;
    bit [31:0] vec [0:3];
    pair_t     pr;
    int        r;
    function void go();
      bit [31:0] loc;
      bit [63:0] locw;
      // bare, converting
      r = fo(1, narr);
      // bare, SAME type (control)
      r = fo(2, same);
      // bit-select, converting
      r = fo(3, narr[0]);
      // part-select, converting
      r = fo(4, narr[7:0]);
      // indexed part-select, converting
      r = fo(5, narr[loc +: 8]);
      // struct member, converting
      r = fo(6, pr.f0);
      // array element, converting
      r = fo(7, vec[2]);
      // class property through this, converting
      r = fo(8, this.narr);
      // inout, converting
      r = fio(9, narr);
      // inout, SAME type (control)
      r = fio(10, same);
      // WIDENING actual -> narrow formal (the other direction)
      r = fw(11, locw);
      // local var, same type (control)
      r = fo(12, locw);
      // local var, converting
      r = fo(13, loc);
    endfunction
  endclass
endpackage
