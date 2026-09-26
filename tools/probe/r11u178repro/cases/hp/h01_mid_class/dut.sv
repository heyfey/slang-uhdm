// § hierPathSelIdxAtPath178
package pack;
typedef struct { string spath; } slice_t;
class concat_c; slice_t slices[]; endclass
class mam;
  function void check();
    concat_c path;
    foreach (path.slices[j]) begin
      string p_ = path.slices[j].spath;
    end
  endfunction
endclass
endpackage
