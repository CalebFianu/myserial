package com.myserial.domain.repository;

import com.myserial.domain.entity.Credit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditRepository extends JpaRepository<Credit, Long> {
    @Query("SELECT c FROM Credit c JOIN FETCH c.person WHERE c.show.id = :showId ORDER BY c.displayOrder ASC")
    List<Credit> findByShowIdOrderByDisplayOrderAsc(@Param("showId") Long showId);

    List<Credit> findByShowIdAndCreditType(Long showId, String creditType);
    List<Credit> findByPersonId(Long personId);
    @org.springframework.transaction.annotation.Transactional
    void deleteByShowId(Long showId);
}
