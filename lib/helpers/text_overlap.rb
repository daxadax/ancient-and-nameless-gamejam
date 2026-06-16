# NOTE: mRuby doesn't include regexp so this is a workaround
module TextOverlap
  SENTENCE_DELIMITERS = ['.', '!', '?'].freeze
  MIN_FRAGMENT_LENGTH = 12
  MIN_OVERLAP_LENGTH = 15

  def self.overlaps_text?(left, right)
    return false unless left && right

    left_norm = normalize_text(left)
    right_norm = normalize_text(right)
    return true if left_norm == right_norm
    return true if left_norm.length > MIN_OVERLAP_LENGTH && right_norm.include?(left_norm)
    return true if right_norm.length > MIN_OVERLAP_LENGTH && left_norm.include?(right_norm)

    shared_fragment?(left, right)
  end

  def self.normalize_text(text)
    squeeze_spaces(
      text.to_s.strip.downcase.chars.map { |char| text_char?(char) ? char : ' ' }.join
    )
  end

  def self.text_char?(char)
    return true if char == ' ' || char == "'"

    ord = char.ord
    (ord >= 48 && ord <= 57) || (ord >= 97 && ord <= 122)
  end

  def self.squeeze_spaces(text)
    result = ''
    text.each_char do |char|
      next if char == ' ' && result[-1] == ' '

      result << char
    end
    result.strip
  end

  def self.shared_fragment?(left, right)
    fragments(left).any? do |frag|
      fragments(right).any? do |other|
        next false if frag.length < MIN_FRAGMENT_LENGTH

        frag == other || frag.include?(other) || other.include?(frag)
      end
    end
  end

  def self.fragments(text)
    split_on_delimiters(text.to_s, SENTENCE_DELIMITERS)
      .flat_map { |part| part.split(',') }
      .map { |part| normalize_text(part) }
      .reject { |part| part.length < MIN_FRAGMENT_LENGTH }
  end

  def self.split_on_delimiters(text, delimiters)
    parts = []
    current = ''

    text.each_char do |char|
      if delimiters.include?(char)
        parts << current unless current.empty?
        current = ''
      else
        current << char
      end
    end

    parts << current unless current.empty?
    parts
  end
end
