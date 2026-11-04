  class obj; endclass
  class obj_cb; endclass
  typedef cb #(obj, obj_cb) obj_cbs_t;
  class user;
    obj_cbs_t h;
    function void f();
      h = obj_cbs_t::get();
    endfunction
  endclass
