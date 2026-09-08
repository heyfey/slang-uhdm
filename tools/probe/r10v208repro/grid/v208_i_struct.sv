// r10v208 arm I — THE NON-DECLARATION OWNER.  A struct MEMBER is neither a
// `variables` nor an `io_decl`, so it contributes NO bit to § 205's owner mask
// nor to § 208's `outer208`.  If a clone body's array declaration shares its
// element chain with a struct member of the same element type, both masks read
// clone-exclusive.  This arm asks whether either law then moves a cell golden
// keeps qualified.
package p208a_vi;
  typedef bit [7:0] bt208vi;
  typedef struct {
    bt208vi mem208[];
    int     tag208;
  } st208vi;
  function automatic int fh208vi(input int n208);
    st208vi s208;
    int a208 = 0;
    foreach (s208.mem208[i208]) a208 += int'(s208.mem208[i208]);
    return a208 + n208 + s208.tag208;
  endfunction
  function automatic int fc208vi(input int n208);
    bt208vi loc208[];
    int a208 = 0;
    foreach (loc208[i208]) a208 += int'(loc208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vi;
  import p208a_vi::*;
  function automatic int gb208vi();
    return fh208vi(1) + fc208vi(2);
  endfunction
endpackage

module v208_i_struct;
  import p208b_vi::*;
  int r208;
  initial r208 = gb208vi();
endmodule
