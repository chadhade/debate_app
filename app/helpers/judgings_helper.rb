module JudgingsHelper

  def time_towords(seconds)
    mm, ss = seconds.divmod(60)
    hh, mm = mm.divmod(60)
    #dd, hh = hh.divmod(24)
    
    return "%d minutes and %d seconds ago" % [mm, ss] if hh == 0
    return "%d hours, %d min. and %d secs ago" % [hh, mm, ss]
  end
end
