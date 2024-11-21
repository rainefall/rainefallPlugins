def pbResolveAudioSE(file)
    return nil if !file
    if RTP.exists?("Audio/SE/" + file, ["", ".wav", ".ogg", ".mp3"])
      return RTP.getPath("Audio/SE/" + file, ["", ".wav", ".ogg", ".mp3"])
    end
    return nil
end

module RTP
    def self.getAudioPath(filename)
        return self.getPath(filename, ["", ".wav", ".wma", ".mid", ".ogg", ".midi", ".mp3"])
    end
end

module FileTest
  AUDIO_EXTENSIONS = [  ".mid", ".midi", ".ogg", ".wav", ".wma", ".mp3", ".aiff", ".mod", ".it", ".xm", ".s3m"]
end