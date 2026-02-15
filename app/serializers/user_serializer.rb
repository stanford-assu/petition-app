class UserSerializer < ActiveJob::Serializers::ObjectSerializer
    # Converts an object to a simpler representative using supported object types.
    # The recommended representative is a Hash with a specific key. Keys can be of basic types only.
    # You should call `super` to add the custom serializer type to the hash.
    def serialize(user_model)
      super(
        user_model.attributes
      )
    end
  
    # Converts serialized value into a proper object.
    def deserialize(hash)
        UserModel.new(hash.except("_aj_serialized"))
    end

    ### Hmmmm, I think I need to be bulk importing here.
  
    private
      # Checks if an argument should be serialized by this serializer.
      def klass
        UserModel
      end
  end