module Robots
  class Detector
    def Detector.is_robot?(user_agent)
      # Stop retarded robots from doing things
      user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
    end
  end
end