import sample_pkg::*;

class sample_impl implements sample_imp_if;
    task delay(longint cycle);
        #(cycle);
        $display("%0t: delayed %0d", $time, cycle);
    endtask

    function longint get_sim_time();
        return $time;
    endfunction
endclass