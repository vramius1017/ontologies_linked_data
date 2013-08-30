module LinkedData
  module Models
    class SubmissionStatus < LinkedData::Models::Base
      VALUES = [
        "UPLOADED", "ERROR_UPLOADED",
        "RDF", "ERROR_RDF",
        "RDF_LABELS", "ERROR_RDF_LABELS",
        "INDEXED", "ERROR_INDEXED",
        "METRICS",  "ERROR_METRICS",
        "ARCHIVED", "ERROR_ARCHIVED"
      ]
      @ready_status = nil

      model :submission_status, name_with: :code
      attribute :code, enforce: [:existence, :unique]
      attribute :submissions,
              :inverse => { :on => :ontology_submission,
              :attribute => :submissionStatus }
      enum VALUES

      def error?
        return self.id.to_s.split("/")[-1].start_with?("ERROR_")
      end

      def get_error_status
        return self if error?
        return SubmissionStatus.find("ERROR_#{self.code}").include(:code).first
      end

      def get_non_error_status
        return self unless error?
        code = self.code.sub("ERROR_", "")
        return SubmissionStatus.find(code).include(:code).first
      end

      def self.status_ready?(status)
        status = status.is_a?(Array) ? status : [status]
        # Using http://ruby-doc.org/core-2.0/Enumerable.html#method-i-all-3F
        all_typed_correctly = status.all? {|s| s.is_a?(LinkedData::Models::SubmissionStatus)}
        raise ArgumentError, "One or more statuses were not SubmissionStatus objects" unless all_typed_correctly

        ready_status_codes = self.get_ready_status
        status_codes = status.map { |s| s.id.to_s.split("/")[-1] }
        return (ready_status_codes - status_codes).size == 0
      end

      def self.get_ready_status
        return [
            "UPLOADED",
            "RDF",
            "RDF_LABELS",
            "INDEXED",
            "METRICS"
        ]
      end
    end
  end
end

