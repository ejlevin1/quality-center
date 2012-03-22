module QualityCenter

  class Parser
    DATE_FIELDS = %w[closing-date creation-time last-modified]
    USER_FIELDS = %w[detected-by owner]
  end

  module RemoteInterface

    class Rest
      AUTHURI  = {
        get:  '/qcbin/authentication-point/login.jsp',
        post: '/qcbin/authentication-point/j_spring_security_check'
      }
      PREFIX  = '/qcbin/rest'
      DEFECTS = '/domains/TEST/projects/AssessmentQualityGroup/defects'
      DOMAIN  = 'TEST'
      PROJECT = 'AssessmentQualityGroup'
      SCOPE   = "domains/#{DOMAIN}/projects/#{PROJECT}"

    end

    class Query
      DIRECTIONS = %w[ASC DESC]
      DEFAULT = {
        paging: { limit: 10,   offset: 0 },
        order:  { field: 'id', direction: 'DESC' }
      }
    end

  end
end