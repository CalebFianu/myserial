package com.myserial.domain.repository;

import com.myserial.domain.entity.Credit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditRepository extends JpaRepository<Credit, Long> {
    List<Credit> findByShowIdOrderByDisplayOrderAsc(Long showId);
    List<Credit> findByShowIdAndCreditType(Long showId, String creditType);
    List<Credit> findByPersonId(Long personId);
    @org.springframework.transaction.annotation.Transactional
    void deleteByShowId(Long showId);
}
