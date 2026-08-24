// r10uvm116 arm H -- how Surelog compiles the IDENTIFIER LIST of a with-form
// scope randomize with more than one name (its paIdentifier_list arm), at two,
// three and four names, plus the `null` spelling that means "randomize
// nothing".  This is the arm that decides whether the identifier-list quirk is
// modellable or must be fenced out.
class lister_h;
  rand int n_one;
  rand int n_two;
  rand int n_three;
  rand int n_four;
  int cap_h;
  function void go();
    if (!randomize(n_one, n_two) with { n_one < n_two; })
      cap_h = 1;
    if (!randomize(n_one, n_two, n_three) with { n_one < n_three; })
      cap_h = 2;
    if (!randomize(n_one, n_two, n_three, n_four) with { n_four > 0; })
      cap_h = 3;
    if (!randomize(n_one, n_two, n_three))
      cap_h = 4;
    if (!randomize(null))
      cap_h = 5;
  endfunction
endclass
module top_h;
  lister_h l_one;
  initial begin
    l_one = new();
    l_one.go();
  end
endmodule
