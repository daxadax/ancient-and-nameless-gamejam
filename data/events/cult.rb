module Events
  module Cult
    def self.all
      [
        {
          id: :spoiled_offering,
          act: :arrival,
          min_threat: 0,
          title: 'Spoiled offering',
          body: 'The bread on the altar became covered in mold overnight. ' \
          'Mara says the nameless reject impure gifts. Aldous blames the damp ' \
          'in the barn. Jules thinks it\'s a sign that there is an unclean presence nearby.',
          choices: {
            one: {
              text: 'Hold the warding ritual anyway',
              faith: 2,
              security: 1,
              provisions: -1
            },
            two: {
              text: 'Bake a fresh loaf of bread',
              provisions: -1,
              faith: 1
            },
            three: {
              text: 'Let Jules patrol the perimeter',
              secrecy: -2,
              security: 1,
              threat: 1,
              flags: { extra_cautious: true }
            }
          }
        },
        {
          id: :dreams,
          act: :arrival,
          min_threat: 0,
          title: 'Dreams',
          body: 'Aldous wakes up screaming. "Bad dreams", he says. Jules, in her ' \
          'omen era, probes him for more information. "A giant loaf of bread ' \
          'was sobbing, but the tears were breast milk from my childhood dog. ' \
          'Dreams," Aldous shrugs. "how do they work?" Mara rolls her eyes and ' \
          'goes back to cross-stitching wards to protect the allium crop. ' \
          '"Where did the tears come out?" Jules asks severely.',
          choices: {
            one: {
              text: 'Help Mara with cross-stitching',
              faith: 1,
              provisions: 1
            },
            two: {
              text: 'Try to get to the bottom of this dream',
              faith: 1,
              flags: { limber_mind: true }
            },
            three: {
              text: 'Go invoke something ancient & nameless',
              faith: 2,
              security: 1,
              threat: -1
            }
          }
        }
      ]
    end
  end
end
