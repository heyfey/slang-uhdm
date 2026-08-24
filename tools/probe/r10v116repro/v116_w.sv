// v116 arm W -- exotic identifier lists and statement shapes for the with-form.
class exotic_w;
  rand int a_w;
  rand int b_w;
  rand int c_w;
  int cap_w;
  function int ret_form();
    return randomize(a_w) with { a_w > 0; };
  endfunction
  function void dup_form();
    if (!randomize(a_w, a_w) with { a_w > 1; })
      cap_w = 1;
  endfunction
  function void three_no_with();
    if (!randomize(a_w, b_w, c_w))
      cap_w = 2;
  endfunction
  task timed();
    #5 if (!randomize(b_w) with { b_w < cap_w; })
      cap_w = 3;
    @(posedge cap_w[0]) if (!randomize(c_w))
      cap_w = 4;
  endtask
  function void nested_w();
    if (!randomize(a_w) with { a_w inside {[1:10]}; a_w != b_w; })
      cap_w = 5;
  endfunction
endclass
module top_w;
  exotic_w w_obj;
  initial begin
    w_obj = new();
    w_obj.dup_form();
  end
endmodule
